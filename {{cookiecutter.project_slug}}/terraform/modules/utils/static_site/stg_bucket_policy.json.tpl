{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RestrictBucketAccessFromSpecificIpAdressRange",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::${stg_bucket}/*"],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${stg_source_ip}"
        }
      }
    }
  ]
}
