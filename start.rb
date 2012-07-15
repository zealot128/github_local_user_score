require_relative "lib/github_score"
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
location = ARGV.join(" ") || "Dresden"
GithubScore.new(location)





