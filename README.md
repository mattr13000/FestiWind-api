# FestiwindApi

💧 A project built with the Vapor web framework.

## Getting Started

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

## Database

To create the tables, use the following command:
```bash
swift run FestiwindApi migrate --yes
```

To clear tables (reverts every migration), use the following command:
```bash
swift run FestiwindApi migrate --revert --yes
```

To create local mockup data for route testing, use the following command:
```bash
swift run FestiwindApi seed
```

To test routes that requires authentication, after migration: 

Staff account: staff@frestiwind.fr / staff1234
User account: user0@festiwind.fr / password123

To reset the database:
```bash
swift run FestiwindApi migrate --revert --yes
swift run FestiwindApi migrate --yes
swift run FestiwindApi seed
```
## Configuration

The project uses a `.env` file for sensitive information
(database, JWT secret). This file is not tracked by Git.

1. Copy the template file:
```
   cp .env.example .env
```
2. Open `.env` and fill in each value. Shared values
   (the team's database) must be requested from a project member.

3. In Xcode, set the scheme's working directory to the project root
   (Product > Scheme > Edit Scheme > Run > Options >
   Use custom working directory), otherwise the `.env` file is not found.
   
### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community maintained packages](https://github.com/vapor-community)


