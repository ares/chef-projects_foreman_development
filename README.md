projects_foreman_development Cookbook
=====================================

This cookbook helps with development setup of Foreman and related projects like smart_proxy,
hammer, kafo and others.

I do not recommend using it in production environment because
  * it uploads x509 certificate and private key for Foreman from this cookbook, created by some custom CA
  * uses password stored as node attribute in cleartext
  * relies on projects cookbook which disables selinux

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

See default attributes for customization options
