package test

import (
	"crypto/tls"
	"encoding/json"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTagsCluster(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "main/tags-web-server")

	// awsRegion := aws.GetRandomRegion(t, nil, nil)
	awsRegion := "us-east-2"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testFolder,

		Vars: map[string]interface{}{
			"region": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	var instanceIDs []string

	instanceIDsStr := terraform.Output(t, terraformOptions, "instances_ids")

	json.Unmarshal([]byte(instanceIDsStr), &instanceIDs)

	for _, instanceID := range instanceIDs {
		instanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)
		assert.Equal(t, "Flugel", instanceTags["Name"])
		assert.Equal(t, "InfraTeam", instanceTags["Owner"])
	}

	lb_dns := terraform.Output(t, terraformOptions, "lb_dns")

	tlsConfig := tls.Config{}

	http_helper.HttpGetWithRetry(t, "http://"+lb_dns, &tlsConfig, 200, "Name=Flugel\nOwner=InfraTeam", 10, 5*time.Second)

}
