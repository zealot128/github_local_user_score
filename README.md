# Super easy github user ranking for towns

Usage:

```bash
ruby start.rb Dresden
```
To list the top 20 users for 'Dresden'
(takes some time)

Additionally, the table information for all users is stored in "Dresden.yml"


## multi-city

```bash
ruby start.rb Plauen Freiberg Zwickau Bautzen Pirna Goerlitz Freital Hoyerswerda Radebeul Riesa Zittau Meissen
```

Aggregated all users and provide a combined rank board.

## Scoring "Algorithm"

I just used the data, given out by the github api, to calculate the score simply by:

```ruby
 def score_for_user(details)
    details.public_gists +
      details.public_repos +
      details.followers * 2 +
      details.following +
      watchers_and_forks
 end
```

Number of Gists + Number of Repos * 2 + Number of Followers * 2  + Number of Following + Numbers of watchers and forks of all own repositories


