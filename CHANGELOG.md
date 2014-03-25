# Change log

## 1.0.5 (March 25, 2014)

IMPROVEMENTS

* Add experimental support to write Kafka (data) log files to a tmpfs mount.  See the new class parameters
  `$tmpfs_manage` (default: false), `$tmpfs_path`, and `$tmpfs_size` in `broker.pp`.  Note that you want to use tmpfs
  only in rare scenarios.


## 1.0.4 (March 24, 2014)

IMPROVEMENTS

* Add `compile` test for `kafka::broker`.


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

