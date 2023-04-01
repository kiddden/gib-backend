import Vapor

func routes(_ app: Application) throws {
    let incidentController = IncidentController()
    try app.register(collection: incidentController)
}
