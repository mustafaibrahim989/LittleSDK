//
//  Drivers.swift
//  LittleSDK
//
//  Created by Gabriel John on 10/05/2021.
//

import Foundation

public class LittleDriver {
    var firstName:String=""
    var lastName:String=""
    var email:String=""
    var driverId:Int=0
    var phone:String=""
    var bio:String=""
    var picture:String=""
    var latitude:Double=0
    var longitude:Double=0
    var rating:Double=0
    var lastTime:String=""
    var lastDistance:String=""
    var carModel:String=""
    var carNumber:String=""
    var carColor:String=""
    var vehicleTypeId:String=""
    var bearing: Double = 0
    
    func getBearing() -> Double {
        return bearing
    }
    func setBearing(bearing: Double) {
        self.bearing = bearing
    }
    func getRating() -> Double {
        return rating
    }
    func setRating(data: Double) {
        rating=data
    }
    func getFirstName() -> String {
        return firstName
    }
    func setFirstName(data: String) {
        firstName=data
    }
    func getLastName() -> String {
        return lastName
    }
    func setLastName(data: String) {
        lastName=data
    }
    func getEmail() -> String {
        return email
    }
    func setEmail(data: String) {
        email=data
    }
    func getPhone() -> String {
        return phone
    }
    func setPhone(data: String) {
        phone=data
    }
    func getBio() -> String {
        return bio
    }
    func setBio(data: String) {
        bio=data
    }
    func getPicture() -> String {
        return picture
    }
    func setPicture(data: String) {
        picture=data
    }
    func getLatitude() -> Double {
        return latitude
    }
    func setLatitude(data: Double) {
        latitude=data
    }
    func getLongitude() -> Double {
        return longitude
    }
    func setLongitude(data: Double) {
        longitude=data
    }
    func getLastTime() -> String {
        return lastTime
    }
    func setLastTime(data: String) {
        lastTime=data
    }
    func getLastDistance() -> String {
        return lastDistance
    }
    func setLastDistance(data: String) {
        lastDistance=data
    }
    func getCarModel() -> String {
        return carModel
    }
    func setCarModel(data: String) {
        carModel=data
    }
    func getCarColor() -> String {
        return carColor
    }
    func setCarColor(data: String) {
        carColor=data
    }
    func getCarNumber() -> String {
        return carNumber
    }
    func setCarNumber(data: String) {
        carNumber=data
    }
    func getVehicleTypeId() -> String {
        return vehicleTypeId
    }
    func setVehicleTypeId(data: String) {
        vehicleTypeId=data
    }
    func getDriverId() -> Int {
        return driverId
    }
    func setDriverId(data: Int) {
        driverId=data
    }
}
