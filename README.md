<!-- DO NOT REMOVE - contributor_list:data:start:["cjdenio"]:end -->

# Uno for Slack

> Some say Slack is a communication tool, but I say it's a gaming platform.

Uno for Slack is fully functional! Feel free to report issues [over here](https://github.com/cjdenio/slack-uno/issues).

![](https://cloud-cfqwrizot.vercel.app/image.png)

## Hosting it yourself

You can host Uno for Slack yourself using the provided `prod.Dockerfile`. Alternatively, you may run the app yourself with `dart bin/main.dart` (requires a [Dart SDK](https://dart.dev) installation)

You'll also need a persistent Redis database.

### Environment variables

```
PORT (the port to run the app on)

SLACK_TOKEN (your Slack bot token)
SLACK_SIGNING_SECRET (your Slack app's signing secret)

REDIS_URL (a Redis url, e.g. redis://localhost:6379)
```

### Creating the Slack app

Head on over to https://api.slack.com/apps and register an app.

### Scopes

Slack for Uno requires the following scopes:
```
chat:write
chat:write.public
```

### Events

Subscribe to the `app_home_opened` event, then set the URL to `<your app>/slack/events`

### Interactivity

Enable interactivity, then set the URL to `<your app>/slack/interactivity`

## Missing Features:

- Wild/Draw 2 cards
- Leave Game button

### [Project board](https://github.com/cjdenio/slack-uno/projects/1)

---

_Image rendering is handled by a separate repo, https://github.com/cjdenio/slack-uno-renderer_

<!-- DO NOT REMOVE - contributor_list:start -->

## 👥 Contributors

- **[@cjdenio](https://github.com/cjdenio)**

<!-- DO NOT REMOVE - contributor_list:end -->
