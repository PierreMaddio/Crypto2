
import Foundation
import CoreData

class PortfolioDataService: NSObject, PortfolioDataServiceProtocol {
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    private var fetchedResultsController: NSFetchedResultsController<PortfolioEntity>!
 
    private var handler: (([PortfolioEntity]) -> Void)?
    
    required override init() {
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

protocol PortfolioDataServiceProtocol {
     init()
    
    // MARK: - PUBLIC
    func updatePortfolio(coin: Coin, amount: Double)
    func getPortfolio() throws -> AsyncStream<[any PortfolioEntityProtocol]>
}

protocol PortfolioEntityProtocol{
    var amount: Double {get set}
    var coinID: String? {get set}
}

extension PortfolioEntity: PortfolioEntityProtocol{

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
    
    required init(){}
    
    func updatePortfolio(coin: Coin, amount: Double) {
        if let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) {
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
    
    func getPortfolio() throws -> AsyncStream<[any PortfolioEntityProtocol]> {
        AsyncStream { continuation in
            continuation.yield(Array(portfolioEntities))
            handler = { entities in
                continuation.yield(entities)
            }
        }
    }
    
    private func add(coin: Coin, amount: Double) {
        let entity = MockPortfolioEntity(amount: amount, coinID: coin.id)
        applyChanges()
    }
    
    private func update(entity: MockPortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: MockPortfolioEntity) {
        print(#function)
        portfolioEntities.remove(entity)
        applyChanges()
    }
    
    func applyChanges(){
        if let handler = handler{
            handler(Array(portfolioEntities))
        } else {
            print("No handler set")
        }
    }
}
