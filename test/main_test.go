package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestEc2(t *testing.T) {
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

func TestS3(t *testing.T) {
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

	bucket_name := terraform.Output(t, terraformOptions, "bucket_name")

	aws.AssertS3BucketExists(t, awsRegion, bucket_name)

	s3Client := aws.NewS3Client(t, awsRegion)
	result, _ := s3Client.GetBucketTagging(
		&s3.GetBucketTaggingInput{
			Bucket: &bucket_name,
		},
	)

	tags := make(map[string]string)

	for _, tag := range result.TagSet {
		key := tag.Key
		value := tag.Value

		tags[*key] = *value
	}

	assert.Equal(t, "Flugel", tags["Name"])
	assert.Equal(t, "InfraTeam", tags["Owner"])
}
