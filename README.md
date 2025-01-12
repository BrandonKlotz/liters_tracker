# LITERS TRACKER
A custom reporting app for 20 Liters

# CURRENT:

# More reports:
* Last Month:
- Display reports by month (a way for Rebero to easily check his submissions)

* By Geography:
- villages#index is too complex to bother with?
- villages#show
--> by facilities per village, using Plan
--> by technologies, using Target

- facilities#index
  -- make searchable?
  -- communicate if a RWHS or SAM2 is present / planned
- facilities#show is pointless?

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.impact | Target.people_goal ]
-- By sector: [ Report.impact | Target.people_goal ]

* 'Add plan' && 'Add report' buttons on technologies#show?by_sector don't do anything, but should
- POLICED by current_user.can_create('Report') && current_user.can_create('Plan')
- Since they vary in their provided params [and since sector/id/report relies on date and tech], we should go to a chooser that considers the provided params.

* technologies#show?by_mou could have 'Add Target' button if it's missing, but these should be pre-built with each new MOU

* technologies#index should also have buttons? [Add Plan, Add Report, Add Target]

# Creating/Updating Targets

# Creating/Updating Plans
* Copy the sector/select && sector/#id/report process

# Forms
-- redirect_back on model#create and #update isn't UX
- Tech form
- Contract form
- Target form
- Plan form
- Dist form
- Sector form
- Cell form
- Village form
+ Facility form (also submits as partial from SectorsController#Reports)
  -- CHECK: Sector lookup is showing the record, not the record.name

# Bugs?
- `sessions/new?return-to` doesn't do anything
- Cells#show grand total rows don't match table
- JS call to /favicons?
- Devise mail doesn't send? Mailgun shows nothing going out.
- No reports on cell#index or village#index because of length, must get to them by sector
- `development restore-from production` doesn't map relationships correctly? Is this a mis-matched PG version between me and Heroku?

# Improvements
- Districts#index doesn't have [Add Plan, Add Report, Add Target] functionality
- Technologies#index doesn't have [Add Plan, Add Report, Add Target] functionality

# SPEED THINGS UP
- check which is faster: `@reports.related_to_village(village)` or `village.related_reports`
  -- Affects cell and village reporting partials
- use `.select()` to speed up queries by only pulling what you need e.g.: `@reports.#stuff.select(:distributed, :checked)`


# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
* production backup / development restore-from production (https://github.com/thoughtbot/parity)
  `User.first.update(password: 'password', password_confirmation: 'password')`
* byebug commands
    continue   -- Runs on
    delete     -- Deletes breakpoints
    finish     -- Runs the program until frame returns
    irb        -- Starts an IRB session
    kill       -- Sends a signal to the current process
    quit       -- Exits byebug
    restart    -- Restarts the debugged program
