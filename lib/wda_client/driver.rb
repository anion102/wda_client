# encoding:utf-8
# author: anion

require_relative 'agent/request'
require_relative 'ios/element'
require_relative 'logger_out'

module WdaClient
  # require http method, for requesting webdriverAgent
  # config findElement api request data

  def self.element_template_operate(opt)
    template = Hash.new
    opt.each do |key,value|

      if key.to_s == 'class name'|| key.to_s == 'xpath'
        template[:using] = key.to_s
        template[:value] = value.to_s

      elsif ['name','label','value'].include?(key.to_s)
        template[:using] = 'link text'
        template[:value] = "#{key.to_s}=#{value}"

      elsif key.to_s=='text'
        template[:using] = 'partial link text'
        template[:value] = "value = #{value}"
      else
        fail 'the attribute do not be supported to locate ios'
      end

    end
    template
  end
  class Driver

    include WdaClient::Agent
    include WdaClient::Ios
    include WdaClient::LoggerOut

    attr_reader :server_url
    attr_reader :device
    attr_reader :browser_name
    attr_reader :sdk_version
    attr_reader :bundle_id
    attr_reader :session
    attr_reader :session_url
    attr_reader :element_id
    attr_reader :element_url

    #init to  WebDriverAgent runing succeed or not
    def initialize(server_url)
      #example http://192.168.2.97:8100
      fail 'server url do not find' if server_url==''||server_url==nil
      @timeout = 10
      @duration=3
      @server_url = server_url
      # get /status
      agent = agent_get(@server_url+'/status')

      fail 'WebDriver Agent running failed or server_url is wrong' if agent==nil
      fail 'WebDriver Agent running failed' if agent['status']!=0 || agent['sessionId']==0
      # Initialize log module
      @logger =WdaClient::LoggerOut.logger
      @logger.info_log('wda_client::driver.init',"connect WebDriverAgent succeed\n")

      $driver = self
      self # return newly created driver
    end

    def start_device(opt={})
      p opt
      fail 'opt must be a hash' unless opt.is_a? Hash

      app_info = opt[:desiredCapabilities]||{}

      @bundle_id = app_info.fetch(:bundleId,false)
      start_resp=agent_post(@server_url+'/session/',opt.to_json)
      #add catch exception
      if start_resp['status']!=0 || start_resp['sessionId']==0
        @logger.info_log('wda_client::driver.start_device',"app launch failed\n")
        fail 'app launch failed'
      end


      #app which tested infos
      @device = start_resp['value']['capabilities']['device']
      @browser_name = start_resp['value']['capabilities']['browserName']
      @sdk_version = start_resp['value']['capabilities']['sdkVersion']
      # set session
      @session = start_resp['sessionId']
      #example http://192.168.2.97:8100/session
      @session_url = @server_url+'/session/'+@session
      @logger.info_log('wda_client::driver.start_device',"the app launched successfully\n")
    end


    def deactivate_app(duration)
      opt={duration:duration}.to_json
      data=agent_post(@session_url+'/deactivateApp',opt)
      p "deactivate_app: #{data}"

    end

    # using: key     =>'name'  'xpath' 'class'
    # value: value   => '登录'
    # template={
    #   using: key
    #   value: value
    # }
    def find_element(opt = {})
      # get ios id
      fail 'find no ios by {}' if opt == {}
      search_element(opt)
      #set element_url
      self
    end


    # operate: click ios on page
    def click_element(opt = {})
      find_element(opt) if opt != {}
      # click @element_id
      url = @element_url+'/click'
      click = agent_post(url,'')
      return click
    end

    # send value to textfield textarea
    def set_value(value)
      # set_value @element_id
      opt = {
          value: value
      }
      url=@element_url + '/value'
      set = agent_post(url,opt.to_json)
      fail 'input for ios failed' unless set['status'] == 0
      return set
    end

    # operate: clear ios value on page
    def handle_clear(opt = {})
      find_element(opt) if opt != {}
      # clear the value of @element_id
      url = @element_url + '/clear'
      clear = agent_post(url,'')
      return clear
    end

    # wait ios to find click so
    def wait_element(opt = {},time = @timeout)
      begin
        wait = Selenium::WebDriver::Wait.new(:timeout => time)
        wait.until {
          search_element(opt).length.equal?(36)
        }
        @logger.info_log('wda_client::driver wait_element',"waiting for ios with #{opt.values } succeed\n")
        return true
      rescue
        @logger.error_log('wda_client::driver wait_element',"waiting for ios with #{opt.values } failed\n")
        return false
      end
    end

  end
end