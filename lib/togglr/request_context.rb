module Togglr
  class RequestContext
    # Predefined attribute keys
    ATTR_USER_ID = 'user.id'.freeze
    ATTR_USER_EMAIL = 'user.email'.freeze
    ATTR_USER_ANONYMOUS = 'user.anonymous'.freeze
    ATTR_COUNTRY_CODE = 'country_code'.freeze
    ATTR_REGION = 'region'.freeze
    ATTR_CITY = 'city'.freeze
    ATTR_MANUFACTURER = 'manufacturer'.freeze
    ATTR_DEVICE_TYPE = 'device_type'.freeze
    ATTR_OS = 'os'.freeze
    ATTR_OS_VERSION = 'os_version'.freeze
    ATTR_BROWSER = 'browser'.freeze
    ATTR_BROWSER_VERSION = 'browser_version'.freeze
    ATTR_LANGUAGE = 'language'.freeze
    ATTR_CONNECTION_TYPE = 'connection_type'.freeze
    ATTR_AGE = 'age'.freeze
    ATTR_GENDER = 'gender'.freeze
    ATTR_IP = 'ip'.freeze
    ATTR_APP_VERSION = 'app_version'.freeze
    ATTR_PLATFORM = 'platform'.freeze

    def initialize
      @attributes = {}
    end

    def self.new
      instance = allocate
      instance.send(:initialize)
      instance
    end

    # Chainable helper methods
    def with_user_id(id)
      @attributes[ATTR_USER_ID] = id
      self
    end

    def with_user_email(email)
      @attributes[ATTR_USER_EMAIL] = email
      self
    end

    def with_anonymous(flag)
      @attributes[ATTR_USER_ANONYMOUS] = flag
      self
    end

    def with_country(code)
      @attributes[ATTR_COUNTRY_CODE] = code
      self
    end

    def with_region(region)
      @attributes[ATTR_REGION] = region
      self
    end

    def with_city(city)
      @attributes[ATTR_CITY] = city
      self
    end

    def with_manufacturer(manufacturer)
      @attributes[ATTR_MANUFACTURER] = manufacturer
      self
    end

    def with_device_type(device_type)
      @attributes[ATTR_DEVICE_TYPE] = device_type
      self
    end

    def with_os(os)
      @attributes[ATTR_OS] = os
      self
    end

    def with_os_version(version)
      @attributes[ATTR_OS_VERSION] = version
      self
    end

    def with_browser(browser)
      @attributes[ATTR_BROWSER] = browser
      self
    end

    def with_browser_version(version)
      @attributes[ATTR_BROWSER_VERSION] = version
      self
    end

    def with_language(language)
      @attributes[ATTR_LANGUAGE] = language
      self
    end

    def with_connection_type(connection_type)
      @attributes[ATTR_CONNECTION_TYPE] = connection_type
      self
    end

    def with_age(age)
      @attributes[ATTR_AGE] = age
      self
    end

    def with_gender(gender)
      @attributes[ATTR_GENDER] = gender
      self
    end

    def with_ip(ip)
      @attributes[ATTR_IP] = ip
      self
    end

    def with_app_version(version)
      @attributes[ATTR_APP_VERSION] = version
      self
    end

    def with_platform(platform)
      @attributes[ATTR_PLATFORM] = platform
      self
    end

    def set(key, value)
      @attributes[key] = value
      self
    end

    def to_h
      @attributes.dup
    end

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value
    end
  end
end
