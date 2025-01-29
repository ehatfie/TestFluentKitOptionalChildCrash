//
//  ContentView.swift
//  TestFluentKitOptionalChildCrash
//
//  Created by Erik Hatfield on 1/29/25.
//

import SwiftUI

@Observable class ViewModel {
    let dbManager = DBManager()
    
    func start() {
        Task {
            
            do {
                try await createModel()
                
            } catch let err {
                print("Create model error \(err)")
            }
            
        }
    }
    
    func createModel() async {
        print("create model")
        let model = ParentModel(characterID: "test")
        do {
            try await model.create(on: dbManager.database).get()
            let optionalChild = OptionalChildModel(value: "test value")
            try await model.$optionalChild.create(optionalChild, on: dbManager.database).get()
        } catch let err {
            print("Error creating model \(err)")
        }
        
        
        //let optionalChild = OptionalChildModel(value: "test value")
    }
    
    func getModel() async {
        do {
            let models = try await ParentModel.query(on: dbManager.database)
                .field(\.$characterId)
                .with(\.$optionalChild)
                .all()
                //.filter { $0.$optionalChild.value == nil}
            print("got \(models)")
            print("optional child \(models.first?.optionalChild)")
        } catch let err {
            print("Error getting models \(err)")
        }
    }
}


struct ContentView: View {
    @State var viewModel = ViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(action: {
                Task {
                    await viewModel.createModel()
                }
            }, label: {
                Text("Create Model")
            })
            
            Button(action: {
                Task {
                    await viewModel.getModel()
                }
            }, label: {
                Text("Press me ")
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
