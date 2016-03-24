projects_foreman_development Cookbook
=====================================

This cookbook helps with development setup of Foreman and related projects like smart_proxy,
hammer, kafo and others.

I do not recommend using it in production environment because
  * it uploads x509 certificate and private key for Foreman from this cookbook, created by some custom CA
  * uses password stored as node attribute in cleartext
  * relies on projects cookbook which disables selinux

Local libvirt setup with provisioning won't work on RHEL 6 or CentOS 6 because they lack
some software we need (NM, polkit, firewalld). You can still use it for installing Foreman
with plugins on these platforms though.

There's similar limitation for SSL client authentication of smart proxy because of too old
nginx that does not support ssl_trusted_certificate. You might need to setup trusted hosts
if you need to allow this communication.

TODO in future: 
  * customizable project owner and branch so you could simply use it to prepare setup with branches of other contributors
  * make certificate customizable through attributes

TODO document setup (at least networking)

Attributes
----------

#### projects_foreman_development::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['projects_foreman_development']['projects']</tt></td>
    <td>Hash</td>
    <td>container of all projects attributes</td>
  </tr>
</table>

Usage
-----
#### projects_foreman_development::default

Just include `projects_foreman_development` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[projects_foreman_development]"
  ]
}
```

For additional plugins you can add their recipes like this

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[projects_foreman_development]"
    "recipe[projects_foreman_development::plugin_discovery]"
  ]
}
```

See default attributes for customization options
