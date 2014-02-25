class kafka::service inherits kafka {

  $brokers = hiera('kafka::brokers', {})
  create_resources('kafka::broker', $brokers)

}
