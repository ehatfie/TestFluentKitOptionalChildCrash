//
//  ContentView.swift
//  TestFluentKitOptionalChildCrash
//
//  Created by Erik Hatfield on 1/29/25.
//

import SwiftUI

@Observable class ViewModel {
    let dbManager = DBManager()
    
    func createModel() async {
        print("create model")
        let model = ParentModel(modelProperty: "test")
        do {
            try await model.create(on: dbManager.database).get()
            let optionalChild = OptionalChildModel(value: "test value")
            try await model.$optionalChild.create(optionalChild, on: dbManager.database).get()
        } catch let err {
            print("Error creating model \(err)")
        }
    }
    
    func getModel() async {
        print("get model")
        do {
            let models = try await ParentModel.query(on: dbManager.database)
                .with(\.$optionalChild)
                .all()
            print("got \(models.count)")
        } catch let err {
            print("Error getting models \(err)")
        }
    }
    
    func getModelCrashes() async {
        print("get model crashes")
        do {
            let models = try await ParentModel.query(on: dbManager.database)
                .field(\.$modelProperty)
                .with(\.$optionalChild)
                .all()
            print("got \(models.count)")
        } catch let err {
            print("Error getting models \(err)")
        }
    }
}


struct ContentView: View {
    @State var viewModel = ViewModel()
    var body: some View {
        VStack {
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
                Text("Get model non crash")
            })
            
            Button(action: {
                Task {
                    await viewModel.getModelCrashes()
                }
            }, label: {
                Text("Get model with crash")
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
