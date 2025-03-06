# Watching the Weather With Github Actions

Updated for NICAR 20245 in Minneapolis ...

Join me ...

- Sign into Github (or quickly make an account if you haven't already): [github.com](https://github.com)
- Go to my Github page **[github.com/jkeefe/](https://github.com/jkeefe)**
- Click on the pinned repository at the top: [weather-newsrooms-nicar25](https://github.com/jkeefe/weather-newsrooms-nicar25)

## Geting Started

### Today's Plan

We'll make a bot that watches for warnings and Slacks them to you.

In the process, you will ...

- Learn about the Weather Service API
- Make your own copy of my code to take home
- Learn about Github Actions
- Learn about Github Codespaces
- Set up Slack to get messages
- Set up Github with the settings you need
- Make it go!

### The slides: A visual guide for where everthing lives

[Slides are here](./slides.pdf).

### The Weather Service API

- Documentation: https://www.weather.gov/documentation/services-web-api
- Click on "Specification"
- Building a URL:
  - Base endpoint: `https://api.weather.gov/alerts/active`
  - We want actual warnings, not tests: `?status=actual`
  - Area: Let's say Minnesota. You can get fancier here, but states are easy: `&area=MN`
  - There's also a "code" option. This is the warning type. Tornado warning, tornado watch, etc. List is [here](https://www.weather.gov/nwr/eventcodes). You could add `&code=TOR` or `@code=TOR,HWW,FFW` for example.
  - Let's leave this tab open

### Make your own copy of my code

In a new browser tab ...

1. Sign into Github (or quickly make an account if you haven't already): [github.com](https://github.com)
1. Return to this page or scroll to the top of this page!
1. Chose the "Fork" button
1. Make sure that the **owner** is now **you**. Click "Create fork"
1. After a minute, you will have a new screen. Note that your name is up at the top! This is your copy. You should use this now. (If you see **jkeefe** instead of your name, you're on the wrong screen. Go find your copy in your github account.)
1. Keep this tab open. We'll call it the **repository tab**.
1. If the `jkeefe` repository is open oinn another tab, close it to avoid confusion.

### Using Codespaces

Normally, when you use Github you _clone_ the code down onto your own computer. Then you type aned code locally. When you're done, you _push_ it back up to Github.

But in this class, we're going to do something different: Code on a computer in the cloud — a computer that's already set up with an environment that works for the code I'm showing you.

This is a temporary, cloud-based computer you use in your browser. You still need to push up your code to the repository save it.

1. Make sure you're on _your_ version of today's repository. You should see your name on at the top of the page (NOT `jkeefe`).
1. Now click the green "<> Code" button and, after you do, the "Codespaces" tab under it.
1. Click "Create Codespace on Main"
1. Wait a minute.
1. We'll be coming back to this tab a lot, and I'll call it the **Codespaces tab**.

### Let's take a look around!

- If you use VS Code, this will look familiar
- Editing happens in the big window
- There's a terminal window at the bottom to run things
- Let's go through the files and folders (skip the Makefile for now)

### Weather Warnings Code

- Look at the Makefile in that folder
- Take a peek at the `SOURCE_URL` at the top
  - If you use this for your work, you'll want to adjust this URL's `area` and `code` values here. See "The Weather Service API" section above.
  - You can also comment out that line, and uncomment line 2 for testing on an old alert I saved
- Open the Terminal, if it's not open already
- Type `make download` ... this downloads everything
- Type `make warnings` ... and see what happens!
- `make clean` clears out what we downloaded so it's fresh
- `make all` does three things: `make clean`, `make download` and `make warnings`

I've already set up Slack to receive my messages. Watch:

- I type `make slack` (this won't work for you ... yet)
- If I do it twice, it won't work. That's good!
- "Seen" warnings are stored in `data/seen.json`

Imagine if we could run this command every few minutes. That'd be pretty useful! :-)

## Making a Warnings Bot

### Understanding the Github Action

Github actions allow you to run your code in the cloud.

_NOTE! This is a **different** computer in the cloud than your Codespace. Technically it's called a "runner" and only exists as long as it takes to run your code._

The driver of any github action is a yaml file in the `.github/workflows` directory of a repository, [like this one](.github/workflows/warnings.yml). Let's take a look.

In your **Codespaces tab**, open the warnings.yml file in the `.github/workflows` directory.

In short, here's what our `warnings` Github Action does:

- It starts running according to a cron statement (here every 10 minutes)
- Spins up a **computer running ubuntu**
- **Checks out** this repository
- **Loads node.js** and installs packages (or it pulls them from a cache if nothing has changed).
- Reads secrets called SLACK_TOKEN and SLACK_CHANNEL ... which we'll set up in a few
- Runs **make all** just like we did in the terminal
- **Commits** the new data and pushes it to the repository (saving our `seen.json` for the next run)

To get this working, you need to do a few key things:

### Change the warnings script we're using

We need to use a slightly more sophisticated warnings script called `warnings-slack.js` instead of `warnings.js`. The new one includes code for sending Slack messages.

We'll adjust our `make all` command to make this change.

- Be sure you're in your **Codespaces tab**.
- On line 4 of your Makefile, where you see `all:`, replace `warnings` with `slack`

It should look like this when you are done:

```
all: clean download slack
```

### Save your work from the Codespace to the repository

In the terminal window (at the bottom of the **Codespaces tab**) ...

- type `git add -A` to add your files to the set you're saving
- type `git commit "set up for slack"` or whatever note makes sense to you for this save
- type `git push origin main` to push up the code, saving it.

### Allow the Action write back to the repository

- Switch to your **repository tab**, the one with `your-name/weather-newsrooms-nicar25` at the top.
- Click through: Settings > Actions > General > Workflow Permissions > Read and write permissions > SAVE
- Don't forget to click "Save!"
  <img width="959" alt="Screenshot 2024-03-06 at 9 49 13 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/daa35671-8fec-4dde-a1d0-d769733097ca">

<img width="868" alt="Screenshot 2024-03-06 at 10 11 08 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/64df0600-0ae7-4857-99d0-45510ee0faa4">

OK, now we need to set up Slack and get some codes from there.

### Setting up Slack to receive real-time warnings

Slack is a messaging platform used by a lot of newsrooms, and it's surprisingly good at showing messages from robots _and_ is great at managing alerts and messages to your phone, etc.

You'll need to make a Slack _app_ (it's easier than that sounds). And you will need to get a "bot token."

The only catch is that depending on your existing Slack setup, you may need to get an administrator to approve the creation of an app. It _should_ be pretty safe to do: yre only requesting the ability to `chat:write`, which is simply posting into a channel. Many admins are okay with this.

Even if they are not, the good thing is that you this will work in a _free Slack workspace_. So even if you don't have full access to your organization's Slack system, you can do this all on your own if you want. Let's do that for fun. There are detailed screenshots of this process [in this issue](https://github.com/jkeefe/weather-newsrooms-nicar25/issues/1).

- Open a new browser tab.
- Go to [slack.com](https://slack.com)
- Chose "Create a new workspace"
- Enter your email
- You'll need to verify your email with a one-time code
- Answer the questions
- Use the "free" option (not "pro")
- Leave this tab open. I'll call this the **Slack workspace tab**.

OK, now we need to make the Slack app. Here's how:

- Open _yet another tab_
- Go to this [Slack app quickstart](https://api.slack.com/start/quickstart) by pasting `https://api.slack.com/start/quickstart` into the new tab
- Do steps 1, 2 and 3
- In step 2, "Requesting Scopes" you just need the `chat:write` scope.
- Note that the bot will only work in channels where the bot is invited (we'll do that in a moment).
- When you are done with all of the steps, the thing you want is the "Bot User OAuth Token" which always starts `oxob-`. That's the token. Copy this into a safe place. If you ever need to get to this token again, go to:
  - Go to https://api.slack.com/apps
  - Sign in if you're not already signed in
  - Click on the app name
  - Click "Install app" on the left side of the screen
  - Copy the "Bot User OAuth Token"
- You can close this tab.

### Make the #alerts channel

Head back to the **Slack workspace tab**.

- In the lefthand column, find and click "Add channels"
- "Create a new channel"
- Call it "#alerts"
- Go to that channel
- Invite the bot to the channel! For example, type: `/invite @warnings_bot` (using whatever you called your bot)
- Next, get the channel ID, which you can find by clicking on the channel name at the very top of the screen.
- The Channel ID is at the very bottom of the pop-up window, and you can click the little copy icon to copy it. Keep it in a safe spot.

<img width="624" alt="Screenshot 2024-09-19 at 1 31 24 PM" src="https://github.com/user-attachments/assets/a6fbb5c6-844d-4ff0-b3da-6cdf90a5c6c5">

### Last steps back at Github

Head back to your Github **repository tab** (not your Codespace)

#### Store your Slack token as a "secret"

We need to let your Github Action know the secret codes to talk to Slack. Github provides a secure vault where you can store these values safely, making them only available to your Actions. Note that for security reasons, you will _not_ be able to see these codes again once you save them here. So be sure they are safely somewhere else. (I keep them in my password manager.)

- Pick: Settings > Secrets and varialbes > Actions > Repository Secrets > New Repository Secret

<img width="569" alt="Screenshot 2024-03-06 at 9 41 52 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/3d1873cf-2bc5-420f-898d-30265864e6a9">
<img width="813" alt="Screenshot 2024-03-06 at 9 43 08 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/599a8e19-1cde-49ff-89b0-9c3e20d84177">

- Enter `SLACK_TOKEN` in the top box
- Paste your "Bot User OAuth Token" which always starts `oxob-` into the larger box
- Click the "Add Secret" button

<img width="912" alt="Screenshot 2024-03-06 at 9 44 53 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/99a855c4-46d7-482e-ad55-5123920e0a0f">

#### Store your Slack channel as a "secret"

- Again, you want a New Repository Secret
- This time, enter `SLACK_CHANNEL` in the top box
- Paste your channel ID in the bottom box.

### Run your Action!

Then ... run your action:

- Actions > warnings > Run workflow dropdown > Run workflow button
  <img width="445" alt="Screenshot 2024-03-06 at 9 40 45 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/6db8365f-30be-4a49-9c31-5b3fa28e2068">
  <img width="589" alt="Screenshot 2024-03-06 at 9 40 54 PM" src="https://github.com/jkeefe/nicar2024-weather/assets/312347/5b535489-b742-43d5-8e8f-ea57a2533ece">

- It'll take a few seconds to start.
- Click the "warnings" label next to the yellow dot to watch it work.

You should see something like this appear in the **#alerts** channel in your **Slack workspace tab**:

<img width="706" alt="Screenshot 2024-09-19 at 1 30 51 PM" src="https://github.com/user-attachments/assets/3b2d6fbc-bdc9-4867-8092-01c950e9687d">

If you click on the "reply" link, you'll see that the bot has included the details as a thread!

<img width="578" alt="Screenshot 2024-09-19 at 1 31 02 PM" src="https://github.com/user-attachments/assets/7548734f-5d8b-4308-b748-ba536c4555ea">

Did the message appear in your Slack workspace? Did the bot throw an error?

If things aren't working, raise your hand. Also you can explore the "Troubleshooting" section below.

Note that if the warning has geodata, you'll get that, too!

### Run the action every 10 minutes

Once it's working, you can make the bot run automatically. Find the `warnings.yml` file in the `.github/workflows` folder.

Then uncomment (so remove the `#` and a single space) from lines 4 and 5. The file should now look exactly like this at the top (the indentations matter and should be exact):

```
name: warnings

on:
  schedule:
    - cron: '*/10 * * * *'   # <-- Set your cron here (UTC). Uses github which can be ~2-10 mins late.
  workflow_dispatch:
```

### Save those changes Codespace to the repository

In the terminal window (at the bottom of the screen) ...

- type `git add -A` to add your files to the set you're saving
- type `git commit "enabled automatic actions"` or whatever note makes sense to you for this save
- type `git push origin main` to push up the code, saving it.

If things are working, you could download the Slack app onto your phone, adjust the notification settings, and you're good to go!

## Troubleshooting

### Try from your Codespace instead of the Action

Go back to your Codespace. You may need to restart it (reload the page and click the restart button).

Your Codespace doesn't know your SLACK_TOKEN and SLACK_CHANNEL secrets, so we need to tell it.

In the terminal window at the bottom, type:

```
export SLACK_TOKEN=[your_token]
```

For example:

```
export SLACK_TOKEN=xoxb-123-456-abc-zyz
```

- In the terminal type:

```
export SLACK_CHANNEL=[channelID] (no spaces)
```

For example:

```
export SLACK_CHANNEL=C123ABC45 (no spaces)
```

- Now type `make all`

## To make the codespace "forget" alerts it's seen

Go into the `data` folder and click on `seen.json`

Replace the contents there with an empty array, which is just a open and closed square bracket, like this:

```
[]
```

Now try `make all` again.

## Saving your work from the Codespace

Your Codespace is an ephemperal computer! It will shut down and then live in your account for a few days. If you don't take any further steps, it will disappear. Which is good!

But to _really_ save your changes, you need to proactively push your code back to your original repository. Here's how:

In the terminal window (at the bottom of the screen) ...

- type `git add -A` to add your files to the set you're saving
- type `git commit "made changes"` or whatever message makes sense to you for this save
- type `git push origin main` to push up the code, saving it.

### Closing up when you're done for the day

Running computers cost money. You get 60 hours free Codespace time every month and 15 gigabytes of storage. The Codespace will shut down after you haven't used it for 30 minutes, but if you'd rather not waste those minutes until it does, you can shut it down like this:

- Go to (github.com/codespaces)[https://github.com/codespaces]
- Pick the three dots next to the Active codespace.
- Chose "Stop codespace"
- Go back to the main tab, and you'll see it's gone
- This is also where you can restart a codespace
