{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjetsFromCloudFront",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${origin_access_identity}"
      },
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::${prod_bucket}/*"]
    }
  ]
}
