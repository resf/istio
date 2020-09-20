package project

import (
	"bytes"
	"io/ioutil"
	"path/filepath"
	"regexp"
	"strings"
)

func ResolveProjects() (Projects, error) {
	dockerfiles, err := filepath.Glob("./docker/*/Dockerfile.*")
	if err != nil {
		return nil, err
	}

	projects := Projects{}

	for i := range dockerfiles {
		parts := strings.Split(dockerfiles[i], "/")
		projectName, dockerfileName := parts[1], parts[2]

		p, ok := projects[projectName]
		if !ok {
			p = &Project{
				Name: projectName,
			}
			projects[projectName] = p
		}

		switch dockerfileName {
		case "Dockerfile.version":
			data, _ := ioutil.ReadFile(dockerfiles[i])
			p.Version = getVersionFromDockerfile(data)
		case "Dockerfile.base":
			p.BaseDockerfile = dockerfiles[i]
		default:
			p.Dockerfiles = append(p.Dockerfiles, dockerfiles[i])
		}

	}

	return projects, nil
}

type Projects = map[string]*Project

type Project struct {
	Name           string
	Version        string
	BaseDockerfile string
	Dockerfiles    []string
}

var re = regexp.MustCompile("FROM.+:v?(.+)")

func getVersionFromDockerfile(data []byte) string {
	v := bytes.Split(data, []byte("\n"))[0]
	matched := re.FindAllStringSubmatch(string(v), 1)
	return matched[0][1]
}
