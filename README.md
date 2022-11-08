Readme更新中，如遇到问题，欢迎微信联系donttrickrick


## SFDX部署步骤

SFDX部署涉及到的手动操作较多，待更新


## CumulusCI部署步骤

1. checkout代码，安装cumulusci，连接你的github账号。guide如下 https://cumulusci.readthedocs.io/en/stable/get-started.html    
    
    1.1 请务必连接github，否则执行下面命令行会报错，连接github命令 `cci service connect github mygithub`
    
2. 打sfdx包
```bash
cci flow run release_unlocked_beta --org beta
```
3. 安装包，部署到scratch org中并执行部署后流程
```bash
cci flow run ci_unlocked_beta --org beta
```
4. 打开scratch org
```bash
cci org browser beta
```
5. 手动配置步骤

    5.1. 下载certificate
    
      Setup -> Certificate and Key Management -> **MQCert_15April2022** -> Download Certificat；下载后本地保存好
      
    5.2. 更新connected app
      
      1) Setup -> App Manager -> **Salesforce_Impersonater_Connected_App** -> Edit
      
      2) 勾选Use digital signatures -> 上传5.1.保存在本地的certificate
      
      3) Setup -> App Manager -> **Salesforce_Impersonater_Connected_App** -> View -> Manage Consumer Details -> Copy Consumer Key
    
    5.3. 更新named credential
    
      1) Setup -> Named Credential -> **Salesforce_Impersonater** -> Paste 5.2.3)的Consumer Key到Issuer

      2) 更新Url和Token Endpoint Url的域名为你的scratch org，注意以my.salesforce.com结尾，如Url为https://data-customization-1973-dev-ed.my.salesforce.com/，Token Endpoint Url为https://data-customization-1973-dev-ed.my.salesforce.com/services/oauth2/token
      

测试代码是 scripts/apex/demo-1.apex 和 scripts/apex/demo-2.apex
