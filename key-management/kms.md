# KMS

## 鍵

- CMK (Customer Master Key)
  - データキーを暗号化するためのキー
- CDK(Customer Data Key)
  - データを暗号化するためのキー

### 暗号化の仕組み

![kms-encryption](/resources/img/kms-encryption.avif)

1. アプリケーションからCDKを生成
2. 暗号化されているCMKを復号
3. CMKでCDKを暗号化
4. CDKとencrypted CDKをアプリケーションに渡す
5. CDKを使用してデータを暗号化
6. 暗号化されたデータと暗号化されたCDKをDBに保存

### 復号化の仕組み

![kms-decryption](/resources/img/kms-decryption.avif)

1. encrypted CDKを取り出す
2. KMSでCMKを復号
3. decrypted CMKでCDKを暗号化
4. decrypted CDKでデータを復号
