package project

import (
	"fmt"
	"strings"
)

func GithubWorkflowFromProject(p *Project) *GithubWorkflow {
	w := &GithubWorkflow{}
	w.Name = p.Name
	w.On = map[string]WorkflowRule{
		"push": {
			Paths: []string{
				fmt.Sprintf("docker/%s/*", p.Name),
			},
		},
	}
	w.Jobs = map[string]*WorkflowJob{}

	if p.BaseDockerfile != "" {
		w.Jobs["base"] = commonJob(p.Name, "base")
	}

	for i := range p.Dockerfiles {
		name := NameFromDockerfile(p.Dockerfiles[i])

		if p.BaseDockerfile != "" {
			w.Jobs[name] = commonJob(p.Name, name, "base")
		} else {
			w.Jobs[name] = commonJob(p.Name, name)
		}
	}

	return w
}

func commonJob(projectName string, name string, needs ...string) *WorkflowJob {
	return &WorkflowJob{
		RunsOn: []string{"ubuntu-latest"},
		Needs:  needs,
		Steps: []*WorkflowStep{
			Uses("actions/checkout@v2"),
			Uses("docker/setup-qemu-action@v1"),
			Uses("docker/setup-buildx-action@v1"),
			Uses("").Named("docker login").Do(`cat > ~/.docker/config.json << EOF
${{ secrets.DOCKER_CONFIG }}
EOF
`),
			Uses("").Do(fmt.Sprintf("cd docker/%s && NAME=%s make build", projectName, name)),
		},
	}
}

type GithubWorkflow struct {
	Name string                  `yaml:"name"`
	On   map[string]WorkflowRule `yaml:"on"`
	Jobs map[string]*WorkflowJob `yaml:"jobs"`
}

type WorkflowRule struct {
	Paths []string `yaml:"paths,omitempty"`
}

type WorkflowJob struct {
	RunsOn []string        `yaml:"runs-on,omitempty"`
	Needs  []string        `yaml:"needs,omitempty"`
	Steps  []*WorkflowStep `steps:"steps,omitempty"`
}

func Uses(uses string) *WorkflowStep {
	return &WorkflowStep{Uses: uses}
}

type WorkflowStep struct {
	Uses string            `yaml:"uses,omitempty"`
	Name string            `yaml:"name,omitempty"`
	With map[string]string `yaml:"with,omitempty"`
	Run  string            `yaml:"run,omitempty"`
}

func (s WorkflowStep) Named(name string) *WorkflowStep {
	s.Name = name
	return &s
}

func (s WorkflowStep) ArgsWith(args map[string]string) *WorkflowStep {
	s.With = args
	return &s
}

func (s WorkflowStep) Do(run string) *WorkflowStep {
	s.Run = run
	return &s
}

func NameFromDockerfile(dockerfile string) string {
	parts := strings.Split(dockerfile, ".")
	return parts[1]
}
