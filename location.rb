class Location
  def self.foursquare
    @foursquare = Foursquare2::Client.new(:oauth_token => APP_CONFIG["foursquare_oauth_token"])
  end

  def self.last_checkin
    last_checkin = foursquare.user_checkins(:limit => 1, :sort => "newestfirst").items.first
  end

  def self.find
    location = last_checkin.venue.location
    [location.city, location.state, location.country].compact.join(", ")
  end

  def self.stored
    REDIS.get(LOCATION_KEY)
  end

  def self.set(value, expiration = nil)
    expiration ||= APP_CONFIG["expire_minutes"]
    REDIS.set(LOCATION_KEY, value)
    REDIS.expire(LOCATION_KEY, expiration)
  end

  def self.cached
    stored || (set(Location.find); stored)
  end
end

