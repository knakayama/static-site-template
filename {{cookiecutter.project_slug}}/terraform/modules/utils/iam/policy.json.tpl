{
  "Version":   "2012-10-17",
  "Statement": [
    {
      "Effect":   "Allow",
      "Action":   "s3:*",
      "Resource": [
        "arn:aws:s3:::${prod_bucket}/*",
        "arn:aws:s3:::${stg_bucket}/*"
      ]
    },
    {
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::*"
      ],
      "Effect": "Allow"
    }
  ]
}
