package test

import (
	"github.com/gruntwork-io/terratest/modules/k8s"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"


	"github.com/gruntwork-io/terratest/modules/helm"
)

// This file contains examples of how to use terratest to test helm chart template logic by rendering the templates
// using `helm template`, and then reading in the rendered templates.
// There are two tests:
// - TestHelmBasicExampleTemplateRenderedDeployment: An example of how to read in the rendered object and check the
//   computed values.
// - TestHelmBasicExampleTemplateRequiredTemplateArgs: An example of how to check that the required args are indeed
//   required for the template to render.

// An example of how to verify the rendered template object of a Helm Chart given various inputs.
func TestHelmBasicExampleTemplateRenderedDeployment(t *testing.T) {
	t.Parallel()

	// Path to the helm chart we will test
	helmChartPath, err := filepath.Abs("../charts/server")
	releaseName := "aqua-console"
	namespaceName := "aqua"
	require.NoError(t, err)

	// Since we aren't deploying any resources, there is no need to setup kubectl authentication or helm home.

	// Set up the namespace; confirm that the template renders the expected value for the namespace.
	//namespaceName := "medieval-" + strings.ToLower(random.UniqueId())
	//logger.Logf(t, "Namespace: %s\n", namespaceName)

	// Setup the args. For this test, we will set the following input values:
	// - containerImageRepo=nginx
	// - containerImageTag=1.15.8
	options := &helm.Options{
		SetValues: map[string]string{
			"platform": "openshift",
			"imageCredentials.username": "info@aquasec.com",
			"imageCredentials.password": "Password1",
		},
		KubectlOptions: k8s.NewKubectlOptions("", "", namespaceName),
	}

	// Run RenderTemplate to render the template and capture the output. Note that we use the version without `E`, since
	// we want to assert that the template renders without any errors.
	// Additionally, although we know there is only one yaml file in the template, we deliberately path a templateFiles
	// arg to demonstrate how to select individual templates to render.
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{})

	// Now we use kubernetes/client-go library to render the template output into the Deployment struct. This will
	// ensure the Deployment resource is rendered correctly.
	var deployment appsv1.Deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)

	// We verify the deployment pod template spec is set to the expected container image value
	expectedContainerImage := "registry.aquasec.com/console:6.0"
	deploymentContainers := deployment.Spec.Template.Spec.Containers
	require.Equal(t, len(deploymentContainers), 1)
	require.Equal(t, deploymentContainers[0].Image, expectedContainerImage)
}

// An example of how to verify required values for a helm chart.
func TestHelmBasicExampleTemplateRequiredTemplateArgs(t *testing.T) {
	t.Parallel()

	// Path to the helm chart we will test
	helmChartPath, err := filepath.Abs("../charts/server")
	releaseName := "helm-basic"
	require.NoError(t, err)

	// Since we aren't deploying any resources, there is no need to setup kubectl authentication, helm home, or
	// namespaces

	// Here, we use a table driven test to iterate through all the required values as subtests. You can learn more about
	// go subtests here: https://blog.golang.org/subtests
	// The struct captures the inputs that we will pass to helm template and a human friendly name so we can identify it
	// in the test output. In this case, each test case will be a complete values input except for one of the required
	// values missing, to test that neglecting a required value will cause the template rendering to fail.
	testCases := []struct {
		name   string
		values map[string]string
	}{
		{
			"MissingContainerImageRepo",
			map[string]string{"containerImageTag": "1.15.8"},
		},
		{
			"MissingContainerImageTag",
			map[string]string{"containerImageRepo": "nginx"},
		},
	}

	// Now we iterate over each test case and spawn a sub test
	for _, testCase := range testCases {
		// Here, we capture the range variable and force it into the scope of this block. If we don't do this, when the
		// subtest switches contexts (because of t.Parallel), the testCase value will have been updated by the for loop
		// and will be the next testCase!
		testCase := testCase

		// The actual sub test spawning. We name the sub test using the human friendly name. Note that we name the sub
		// test T struct to subT to make it clear which T struct corresponds to which test. However, in most cases you
		// will not reference the main test T so you can name it the same.
		t.Run(testCase.name, func(subT *testing.T) {
			subT.Parallel()

			// Now we try rendering the template, but verify we get an error
			options := &helm.Options{SetValues: testCase.values}
			_, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{})
			require.Error(t, err)
		})
	}
}