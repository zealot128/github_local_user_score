
require "formatador"
require "github_api"
require "open-uri"
require "progressbar"
require "yaml"

class GithubScore
  attr_accessor :all_users, :scores
  attr_reader :city
  def initialize(city)
    @city = city
    @all_users = []
    @scores = []

    find_users_for_city
    calculate_score_for_users
    finish
  end



  def g; @g || Github.new end
  private
  def find_users_for_city
    # pagination
    100.times do |i|
      users = g.search.users(keyword: city, start_page: i + 1)["users"] rescue []
      @all_users += users
      break if users.count < 100
    end
    $stderr.puts "#{all_users.count} potential users found with '#{city}' somewhere"
    @all_users = all_users.select{|i| i[:location][/#{city}/i] }
    puts "#{all_users.count} have locations = '#{city}'"
  end

  def calculate_score_for_users
    pbar = ProgressBar.new("Fetching Scores", all_users.count)
    all_users.each do |user|
      pbar.inc
      begin
        details = OpenStruct.new(g.users.get user: user[:login])
        scores << {
          position: nil,
          login:    details.login,
          score:    score_for_user(details),
          name:     details.name,
          location: details.location
        }
      rescue Github::Error::NotFound
        $stderr.puts "user #{user[:login]} not found - ignoring\n"
      end
    end
    pbar.finish
    scores.sort_by!{|i| -i[:score] }
    @scores = scores.each_with_index.map{|x,i| x[:position] = i + 1; x}
  end

  def finish
    filename = city.gsub(/[^\w]+/, "_") + ".yml"

    $stderr.puts "Saving results to #{filename}"
    File.open(filename, "w+") { |f| f.write scores.to_yaml }


    puts "TOP 20 in #{city}"
    Formatador.display_table(scores[0...20], [:position, :login, :score, :name, :location] )
  end

  def score_for_user(details)
    details.public_gists +
      details.public_repos * 2 +
      details.followers * 3 +
      details.following
  end
end
