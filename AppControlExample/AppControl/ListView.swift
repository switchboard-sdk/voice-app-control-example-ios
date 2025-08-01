import SwiftUI

class ListViewModel: ObservableObject {
    @Published var items = DataSource.shared.movieData
    @Published var selectedIndex = 0
    @Published var isExpanded = false
    
    func up() {
        selectedIndex = selectedIndex == 0 ? items.count - 1 : selectedIndex - 1
        isExpanded = false
    }
    
    func down() {
        selectedIndex = (selectedIndex + 1) % items.count
        isExpanded = false
    }
    
    func toggleLike() {
        items[selectedIndex].likeState = items[selectedIndex].likeState == .liked ? .neutral : .liked
    }
    
    func toggleDislike() {
        items[selectedIndex].likeState = items[selectedIndex].likeState == .disliked ? .neutral : .disliked
    }
    
    func toggleExpand() {
        isExpanded.toggle()
    }
    
    func selectItem(at index: Int) {
        selectedIndex = index
        isExpanded = false
    }
}

struct ListView: View {
    @ObservedObject var viewModel: ListViewModel
    
    var body: some View {
        VStack() {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(0..<viewModel.items.count, id: \.self) { index in
                            ItemView(
                                item: viewModel.items[index],
                                isSelected: index == viewModel.selectedIndex,
                                isExpanded: index == viewModel.selectedIndex && viewModel.isExpanded
                            )
                            .id(index)
                            .onTapGesture {
                                viewModel.selectItem(at: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    proxy.scrollTo(viewModel.selectedIndex, anchor: .center)
                }
                .onChange(of: viewModel.selectedIndex) { _, newIndex in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct ItemView: View {
    let item: Item
    let isSelected: Bool
    let isExpanded: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                Text(item.description)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isExpanded ? nil : 2)
            }
            
            Spacer()
            
            Text(item.likeState == .liked ? "👍" : item.likeState == .disliked ? "👎" : " ")
                .font(.title2)
                .frame(width: 32, height: 32)
        }
        .frame(minHeight: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.green.opacity(0.3) : Color.green.opacity(0.1))
        )
    }
}

#Preview {
    ListView(viewModel: ListViewModel())
}
