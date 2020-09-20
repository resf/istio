package main

import (
	"fmt"
	"github.com/querycap/istio/pkg/project"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
)

func main() {
	projects, err := project.ResolveProjects()
	if err != nil {
		panic(err)
	}

	for _, p := range projects {
		w := project.GithubWorkflowFromProject(p)
		writeWorkflow(w)

		// sync
		for i := range p.Dockerfiles {
			name := project.NameFromDockerfile(p.Dockerfiles[i])
			dockerfile := fmt.Sprintf("sync/Dockerfile.%s", name)

			_ = ioutil.WriteFile(dockerfile, []byte(fmt.Sprintf("FROM querycapistio/%s:%s", name, p.Version)), os.ModePerm)
			writeWorkflow(GithubWorkflowForSync(name, dockerfile))
		}
	}
}

func writeWorkflow(w *project.GithubWorkflow) {
	data, _ := yaml.Marshal(w)
	_ = ioutil.WriteFile(fmt.Sprintf(".github/workflows/%s.yml", w.Name), data, os.ModePerm)
}

func GithubWorkflowForSync(name string, dockerfile string) *project.GithubWorkflow {
	w := &project.GithubWorkflow{}
	w.Name = "sync-" + name
	w.On = map[string]project.WorkflowRule{
		"push": {
			Paths: []string{
				dockerfile,
			},
		},
	}
	w.Jobs = map[string]*project.WorkflowJob{
		"sync": {
			RunsOn: []string{ "self-hosted", "linux", "ARM64" },
			Steps: []*project.WorkflowStep{
				project.Uses("actions/checkout@v2"),
				project.Uses("docker/setup-qemu-action@v1"),
				project.Uses("docker/setup-buildx-action@v1"),
				project.Uses("").Named("docker login").Do(`cat > ~/.docker/config.json << EOF
${{ secrets.DOCKER_CONFIG }}
EOF
`),
				project.Uses("").Do(fmt.Sprintf(`cd sync && NAME=%s make sync`, name)),
			},
		},
	}

	return w
}
