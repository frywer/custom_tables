Redmine Custom Tables
==================

This plugin lets you to create query tables using redmine custom fields.


Compatibility
-------------

This version is supported by Redmine 3.4.1


Installation and Setup
----------------------

* Clone or [download](https://github.com/frywer/custom_tables/archive/master.zip) this repo into your **redmine_root/plugins/** folder

```
$ git clone https://github.com/frywer/custom_tables.git
```
* If you downloaded a tarball / zip from master branch, make sure you rename the extracted folder to `glad_custom_tables`
* You have to run the plugin rake task to provide the assets (from the Redmine root directory):
```
$ rake redmine:plugins:migrate RAILS_ENV=production
```
* Restart redmine
