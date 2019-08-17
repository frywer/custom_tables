Redmine Custom Tables
==================

This plugin provides a possibility to create custom tables. The table is build with Redmine custom fields. It allows you to create any databases you need for your business and integrate it into your workflow processes.

Features
-------------
* Table constructor
* Filtering 
* Sorting 
* Grouping
* Integration with issues
* History of changes
* Commenting entities
* Export CSV/PDF
* API

Compatibility
-------------
* Redmine 4.0.0 or higher

Installation and Setup
----------------------

* Clone or [download](https://github.com/frywer/custom_tables/archive/master.zip) this repo into your **redmine_root/plugins/** folder

```
$ git clone https://github.com/frywer/custom_tables.git
```
* If you downloaded a tarball / zip from master branch, make sure you rename the extracted folder to `custom_tables`
* You have to run the plugin rake task to provide the assets (from the Redmine root directory):
```
$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```
* Restart redmine
