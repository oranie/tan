require 'sinatra/base'
require 'mysql2'

class Tan < Sinatra::Base
  base_url = 'http://localhost:5000'

  set :public_folder, File.dirname(__FILE__) + '/static'
  set :port, 5000

  configure do
    use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
  end

  helpers do
    def random_string
      s = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
      (0...8).map { s[rand(s.length)] }.join
    end

    def conn
      if not $mysql
        $mysql = Mysql2::Client.new(
          :host => '127.0.0.1',
          :port => 3306,
          :username => 'tan',
          :password => 'tan',
          :database => 'tan',
          :reconnect => true,
        )
      end
      $mysql
    end

  end

  get '/' do
    mysql = conn
    results = mysql.query('select shortened_url from tan order by created_at desc limit 10')
    shortened_urls = []
    results.each do |r|
      shortened_urls.push(r["shortened_url"])
    end

    result = session[:result]
    erb :tan, :locals => {
      :history => shortened_urls,
      :result => result
    }
  end

  post '/' do
    real_url = params[:url]
    shortened_url = "#{base_url}/#{random_string}"
    real_url_hash = Digest::SHA1.hexdigest("#{real_url}")
    mysql = conn
    used = mysql.query('select real_url_hash from tan where real_url_hash = "#{real_url_hash}"').first()
    p used
    if used.nil? then
        shotend_url = mysql.query('select "{shotend_url}" from tan where real_url_hash = "#{real_url_hash}"').first()
    else
        mysql.query("insert into tan (shortened_url, real_url, real_url_hash,created_at) values ('#{shortened_url}', '#{real_url}','#{real_url_hash}', '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}')")
    end

    session[:result] = shortened_url
    redirect '/'
  end

  get '/:key' do
    key = params[:key]
    shortened_url = "#{base_url}/#{key}"

    mysql = conn
    result = mysql.query("select real_url from tan where shortened_url = '#{shortened_url}'").first()
    redirect result["real_url"]
  end

  run! if app_file == $0

end
