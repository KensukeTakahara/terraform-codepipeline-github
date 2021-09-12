# terraform-codepipeline-github

## 全体像
![codepipeline-terraform drawio (1)](https://user-images.githubusercontent.com/30205372/132990920-87535d69-f02c-4b81-89ee-6d1946d42b0a.png)

CodePipeline の構成は以下のようになっています。

|  ステージ |  プロバイダ  |
| ---- | ---- |
|  Source  |  CodeStar SourceConnection |
|  Build  |  CodeBuild  |
|  Deploy  |  ECS  |

アーティファクトを格納するための S3 バケットを用意し、各ステージ用にパスを分けています。  
CodeBuild の成果物はコンテナイメージなので ECR に格納し、ECS からアクセスさせます。

## 実行環境

Terraform は version 1.0.5、AWS Provider は version 3.58.0 を使用しました。

## プロビジョニング

```sh
terraform init
terraform apply
```

## 記事
Source ステージについてのみ[Qiita 記事](https://qiita.com/KensukeTakahara/items/6ed83e83620b86b748b7)を書きました。

## 注意事項

CodeBuild だと[Docker Hub のダウンロード制限](https://www.docker.com/blog/scaling-docker-to-serve-millions-more-developers-network-egress/)に引っかかる事があります。
