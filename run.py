"""
docker run -d -p 9000:9000 --name minio -v $PWD/data:/data \
  -e "MINIO_ACCESS_KEY=AKIA0123456789ABCDEF" \
  -e "MINIO_SECRET_KEY=0123456789/abcdefghi/ABCDEFGHI0123456789" \
  minio/minio server /data
"""

import os
import boto3

bucket_name = 'sample'  # バケット名
use_minio = True  # MinIOを使うかどうか
os.environ['AWS_ACCESS_KEY_ID'] = 'AKIA0123456789ABCDEF'
os.environ['AWS_SECRET_ACCESS_KEY'] = '0123456789/abcdefghi/ABCDEFGHI0123456789'

kwargs = dict(
    region_name="ap-northeast-1",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
)

if use_minio:
    kwargs["endpoint_url"] = "http://127.0.0.1:9000"
    # kwargs["endpoint_url"] = "http://localhost:9000/minio/"

bucket = boto3.resource("s3", **kwargs).Bucket(bucket_name)

#bucket.create()  # バケット作成
bucket.upload_file("sample/hoge", "upload_file")  # upload_fileとしてアップロード
print(list(bucket.objects.all()))  # ファイル一覧
bucket.download_file("upload_file", "download_file")  # download_fileとしてダウンロード
#bucket.Object("upload_file").delete()  # ファイル削除
#bucket.delete()  # バケット削除


