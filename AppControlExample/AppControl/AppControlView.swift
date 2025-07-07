import SwiftUI
import Foundation

class AppControlDelegate: NSObject, ControlDelegate, ObservableObject {
    @Published var detectedKeyword = ""
    
    weak var verticalListViewModel: ListViewModel?
    
    // Trigger mode handler with detected keyword
    func triggerDetected(_ triggerType: Int, withKeyword keyword: String) {
        guard let mode = TriggerType(rawValue: triggerType) else { return }
        
        DispatchQueue.main.async {
            self.detectedKeyword = keyword
            
            switch mode {
            case .next:
                self.verticalListViewModel?.goNext()
            case .back:
                self.verticalListViewModel?.goBack()
            case .like:
                self.verticalListViewModel?.toggleLike()
            case .dislike:
                self.verticalListViewModel?.toggleDislike()
            case .expand:
                self.verticalListViewModel?.toggleExpand()
            case .runtimeTriggers:
                // Find the movie by title and select it
                if let movieIndex = self.verticalListViewModel?.items.firstIndex(where: { $0.title.lowercased() == keyword }) {
                    self.verticalListViewModel?.selectItem(at: movieIndex)
                }
            case .unknown:
                print("unknown command")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.detectedKeyword = ""
        }
    }
}

struct AppControlView: View {
    @StateObject private var delegate = AppControlDelegate()
    @StateObject private var verticalListViewModel = ListViewModel()
    @State private var example: AppControlExample?

    var body: some View {
        VStack(spacing: 10) {
            Text("Voice Control Demo")
                .font(.title)
                .padding()
            
            Text("- You can navigate by saying title of a movie \n- Execute actions with following commands \n- Up | Down | Like | Dislike | Expand")
            
            Text(delegate.detectedKeyword)
                .fontWeight(.semibold)
                .font(.callout)
                .frame(minHeight: 20)

            Spacer()
            
            ListView(viewModel: verticalListViewModel)
            
        }
        .padding()
        .onAppear {
            example = AppControlExample()
            example?.createEngine()
            example?.delegate = delegate
            delegate.verticalListViewModel = verticalListViewModel
            
            // Set runtime triggers with movie titles from data
            let movieTitles = DataSource.shared.movieData.map { $0.title }
            example?.setRuntimeTriggers(movieTitles)
            
            example?.startEngine()
        }
        .onDisappear {
            example?.stopEngine()
        }
    }
}
