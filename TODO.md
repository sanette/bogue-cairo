# Threading

For very long rendering graphics, propose to render the Cairo part in
another thread?  (SDL rendering calls cannot be run from another
thread, but mayby Cairo calls may.)

