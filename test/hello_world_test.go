package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestHelloWorld(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "main")

	awsRegion := aws.GetRandomRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testFolder,

		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	instanceID := terraform.Output(t, terraformOptions, "instance_id")

	instanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)

	assert.Equal(t, "Flugel", instanceTags["Name"])
	assert.Equal(t, "InfraTeam", instanceTags["Owner"])
}
