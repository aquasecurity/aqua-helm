package test

import (
	"github.com/stretchr/testify/require"
	"path/filepath"
	"testing"

	corev1 "k8s.io/api/core/v1"

	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestPodTemplateRendersContainerImage(t *testing.T) {
	t.Parallel()

	// Path to the helm chart we will test
	helmChartPath, err := filepath.Abs("../charts/server/")
	require.NoError(t, err)
	// Setup the args. For this test, we will set the following input values:
	// - image=nginx:1.15.8
	options := &helm.Options{
		SetValues: map[string]string{
			"image": "server:6.0",
			"platform": "gke",
			"imageCredentials.username": "info@aquasec.com",
			"imageCredentials.password": "Password1",
		},
	}

	// Run RenderTemplate to render the template and capture the output.
	output := helm.RenderTemplate(t, options, helmChartPath, "pod", []string{})
	// Now we use kubernetes/client-go library to render the template output into the Pod struct. This will
	// ensure the Pod resource is rendered correctly.
	var pod corev1.Pod
	helm.UnmarshalK8SYaml(t, output, &pod)

	// Finally, we verify the pod spec is set to the expected container image value
	expectedContainerImage := "server:6.0"
	podContainers := pod.Spec.Containers
	if podContainers[0].Image != expectedContainerImage {
		t.Fatalf("Rendered container image (%s) is not expected (%s)", podContainers[0].Image, expectedContainerImage)
	}
}