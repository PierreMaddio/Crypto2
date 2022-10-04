
import Foundation
import CoreData

class PortfolioDataService: NSObject, PortfolioDataServiceProtocol {
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    private var fetchedResultsController: NSFetchedResultsController<PortfolioEntity>!
    
    private var handler: (([PortfolioEntity]) -> Void)?
    
    required init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: containerName)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (_, error )in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
        }
        super.init()
    }
    
    private func initializeFetchedResultsController() throws -> [PortfolioEntity] {
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
    func updatePortfolio(coin: Coin, amount: Double) throws {
        // check if coin already in portfolio
        if let entity = fetchedResultsController.fetchedObjects?.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                // print("\(#function) ::  update")
                try update(entity: entity, amount: amount)
            } else {
                // print("\(#function) ::  delete")
                try delete(entity: entity)
            }
        } else {
            // print("\(#function) ::  add")
            try add(coin: coin, amount: amount)
        }
    }
    
    // MARK: - PRIVATE
    func getPortfolio() throws -> AsyncStream<[PortfolioEntityProtocol]> {
        let initial = try initializeFetchedResultsController()
        return AsyncStream { continuation in
            continuation.yield(initial)
            handler = { entities in
                continuation.yield(entities)
            }
            continuation.onTermination = { [ self] _ in
                Task{
                    await MainActor.run {
                        fetchedResultsController.delegate = nil
                        handler = nil
                    }
                }
            }
        }
    }
    
    private func add(coin: Coin, amount: Double) throws {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        try applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) throws {
        entity.amount = amount
        try applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) throws {
        container.viewContext.delete(entity)
        try applyChanges()
    }
    
    private func save() throws{
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to core Data. \(error)")
            throw error
        }
    }
    
    private func applyChanges() throws{
        try save()
    }
}

extension PortfolioDataService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let handler = handler {
            handler((controller.fetchedObjects as? [PortfolioEntity]) ?? [])
        }else{
            print("\(type(of: self)) :: \(#function) :: No Controller handler set")
        }
    }
}

protocol PortfolioDataServiceProtocol {
    init(inMemory: Bool)
    
    // MARK: - PUBLIC
    func updatePortfolio(coin: Coin, amount: Double) throws
    func getPortfolio() throws -> AsyncStream<[any PortfolioEntityProtocol]>
}

protocol PortfolioEntityProtocol {
    var amount: Double {get set}
    var coinID: String? {get set}
}

extension PortfolioEntity: PortfolioEntityProtocol {
    
}

class MockPortfolioEntity: PortfolioEntityProtocol, Hashable {
    static func == (lhs: MockPortfolioEntity, rhs: MockPortfolioEntity) -> Bool {
        lhs.amount == rhs.amount && lhs.coinID == rhs.coinID
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(amount)
        hasher.combine(coinID)
    }
    var amount: Double = 0.0
    
    var coinID: String?
    
    init(amount: Double, coinID: String? = nil) {
        self.amount = amount
        self.coinID = coinID
    }
    
}

class MockPortfolioDataService: PortfolioDataServiceProtocol {
    var portfolioEntities: Set<MockPortfolioEntity> = .init()
    private var handler: (([MockPortfolioEntity]) -> Void)?
    
    required init(inMemory: Bool = false) {}
    
    func updatePortfolio(coin: Coin, amount: Double) throws{
        if let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
    
    func getPortfolio() throws -> AsyncStream<[any PortfolioEntityProtocol]> {
        AsyncStream { continuation in
            // initial value yield
            continuation.yield(Array(portfolioEntities))
            // additional updates
            handler = { entities in
                //print("\(#function) :: return :: \(entities.count)")
                continuation.yield(entities)
            }
        }
    }
    
    private func add(coin: Coin, amount: Double) {
        let entity = MockPortfolioEntity(amount: amount, coinID: coin.id)
        portfolioEntities.insert(entity)
        applyChanges()
    }
    
    private func update(entity: MockPortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: MockPortfolioEntity) {
        portfolioEntities.remove(entity)
        applyChanges()
    }
    
    func applyChanges() {
        //print("\(#function) :: \(portfolioEntities.count)")
        if let handler = handler {
            handler(Array(portfolioEntities))
        } else {
            print("No handler set")
        }
    }
}
