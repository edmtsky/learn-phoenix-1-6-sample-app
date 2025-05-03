- static pages
  - create phoenix app
  - add automated testing
  - use a common templates in layout

- styling and routes
  - add site navigation
  - add Bootstrap, SASS and Popper.js, configure esbuild, add package.json
  - finished a site layout with decent styling
  - add named routes for the Home, About, Help and Contact pages
  - use the named routes in the site layout
  - layout link tests (integration(for links) and unit (for typo in title))
  - and signup route: add User controller and :new action

- modeling users
  - User schema and the Accounts context
  - ecto changesets and validations
  - Adding a secure password
    - initial password system (to store hashes of the passwords)
    - minimal password length
    - add ex_machina
    - add Accounts.authenticate_by_email_and_pass

- sign-up
  - debug information
  - Users resource
  - Gravatar image and sidebar
  - signup error messages
  - test for invalid submition
  - redirect to user profile after successful signup
  - flash message
  - test for valid submission

- basic login
  - sessions
    - add session controller
    - find and authenticate a user with a flash message
  - loggin in
    - Authentication Plug
    - AuthPlug.login
    - changing the layout links with tests
    - login upon signup
    - logging out

- advanced login
  - remember me
    - generate and verify remember token
    - login with remembering
    - fixing the logout function
  - remember-me checkbox
  - remember tests
    - testing remember-me checkbox
    - testing the remember branch

- updating-users
  - edit form
