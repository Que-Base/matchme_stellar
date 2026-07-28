//
//  ProfileViewModelTests.swift
//  matchme.mobile_swiftTests
//
//  ISS-041: Unit tests for ProfileViewModel — init from User,
//  field mapping, and completion score calculation.
//

import XCTest
@testable import matchme_mobile_swift

final class ProfileViewModelTests: XCTestCase {

    // MARK: - init(from user:) mapping

    func test_initFromUser_mapsFullnameToFirstAndLastName() {
        let user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.firstName, "Ada")
        XCTAssertEqual(vm.lastName, "Lovelace")
    }

    func test_initFromUser_singleWordName_setsFirstNameOnly() {
        let user = User(id: "1", fullname: "Cher", email: "cher@example.com")
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.firstName, "Cher")
        XCTAssertEqual(vm.lastName, "")
    }

    func test_initFromUser_mapsOccupation() {
        var user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        user.occupation = "Engineer"
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.occupation, "Engineer")
    }

    func test_initFromUser_defaultsToEmptyOccupationWhenNil() {
        let user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.occupation, "")
    }

    func test_initFromUser_mapsInterests() {
        var user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        user.interests = ["Maths", "Poetry"]
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.interests, ["Maths", "Poetry"])
    }

    func test_initFromUser_defaultsToEmptyInterestsWhenNil() {
        let user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.interests, [])
    }

    func test_initFromUser_mapsProfileSetupCompletion() {
        var user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        user.profileSetupCompletion = 0.8
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.profileSetupComplition, 0.8, accuracy: 0.001)
    }

    func test_initFromUser_defaultsToLowCompletionWhenNil() {
        let user = User(id: "1", fullname: "Ada Lovelace", email: "ada@example.com")
        let vm = ProfileViewModel(from: user)
        XCTAssertEqual(vm.profileSetupComplition, 0.1, accuracy: 0.001)
    }

    // MARK: - jostevModel fallback

    func test_jostevModel_hasNonEmptyFirstName() {
        let vm = ProfileViewModel.jostevModel(premiumAccount: false, profileSetupComplition: 0.5)
        XCTAssertFalse(vm.firstName.isEmpty)
    }
}
