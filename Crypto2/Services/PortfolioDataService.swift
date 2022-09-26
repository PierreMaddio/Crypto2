
import Foundation
import CoreData

class PortfolioDataService: NSObject {
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    private var fetchedResultsController: NSFetchedResultsController<PortfolioEntity>!
    //@Published var savedEntities: [PortfolioEntity] = []
    private var handler: (([PortfolioEntity]) -> Void)?
    
    override init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_, error )in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
        }
        super.init()
    }
    
    private func initializeFetchedResultsController() throws -> [PortfolioEntity] {
        print(#function)
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        let lastNameSort = NSSortDescriptor(key: "coinID", ascending: true)
        request.sortDescriptors = [lastNameSort]
        
        let moc = container.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    // MARK: - PUBLIC
    func updatePortfolio(coin: Coin, amount: Double) {
        print(#function)
        // check if coin already in portfolio
        if let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                print("\(#function) ::  update")
                update(entity: entity, amount: amount)
            } else {
                print("\(#function) ::  delete")
                delete(entity: entity)
            }
        } else {
            print("\(#function) ::  add")
            add(coin: coin, amount: amount)
        }
    }
    
    // MARK: - PRIVATE
    func getPortfolio() throws -> AsyncStream<[PortfolioEntity]> {
        let initial = try initializeFetchedResultsController()
        return AsyncStream { continuation in
            continuation.yield(initial)
            handler = { entities in
                continuation.yield(entities)
            }
        }
    }
    
    private func add(coin: Coin, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) {
        print(#function)
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to core Data. \(error)")
        }
    }
    
    private func applyChanges() {
        save()
    }
}

extension PortfolioDataService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        if let handler = handler {
            handler((controller.fetchedObjects as? [PortfolioEntity]) ?? [])
        }else{
            print("\(type(of: self)) :: \(#function) :: No Controller handler set")
        }
    }
}
