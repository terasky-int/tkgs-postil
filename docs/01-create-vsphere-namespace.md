# Configure Supervisor Namespace

From the vSphere UI, go back to the `Workload Management` page, open the `Namespaces` tab, and click the `New Namespace` button.

![13](namespace-img/13.png)

Click the `Add Permissions` button under the `Permissions` section. Select your identity source for authentication, then select a user or group and the desired permission level.

![14](namespace-img/14.png)

In this example, `tkg-admins` is used as an Active Directory user group with the `Owner` permission level.

![15](namespace-img/15.png)

Click the `Add Storage` button under the Storage section and select your storage policy.

![16](namespace-img/16.png)

![17](namespace-img/17.png)

Click the `Add VM Class` button under the `VM Service` section and select the relevant VM classes.

![18](namespace-img/18.png)
