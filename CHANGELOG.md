# Change log

## 1.0.3 (March 17, 2014)

IMPROVEMENTS

* Add `$user_manage` and `$group_manage` parameters.
* Add more unit tests.


## 1.0.2 (March 14, 2014)

IMPROVEMENTS

* Initial support for testing this module.
    * A skeleton for acceptance testing (`rake acceptance`) was also added.

BACKWARDS INCOMPATIBILITY

* Change default value of `$package_ensure` from "latest" to "present".
* Puppet module fails if run on an unsupported platform.  Currently we only support the RHEL OS family.

BUG FIXES

* Properly generate broker configuration when multiple directories are specified for `$log_dirs`.


## 1.0.1 (March 11, 2014)

IMPROVEMENTS

* Recursively create directories defined via `$log_dirs` if needed.


## 1.0.0 (February 25, 2014)

* Initial release.

