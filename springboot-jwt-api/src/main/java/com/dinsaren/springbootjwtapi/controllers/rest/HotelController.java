package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.CategoryHotel;
import com.dinsaren.springbootjwtapi.models.Floor;
import com.dinsaren.springbootjwtapi.models.Hotel;
import com.dinsaren.springbootjwtapi.models.Room;
import com.dinsaren.springbootjwtapi.models.req.BasePostReq;
import com.dinsaren.springbootjwtapi.models.res.MessageRes;
import com.dinsaren.springbootjwtapi.repository.CategoryHotelRepository;
import com.dinsaren.springbootjwtapi.repository.FloorRepository;
import com.dinsaren.springbootjwtapi.repository.HotelRepository;
import com.dinsaren.springbootjwtapi.repository.RoomRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.ArrayList;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/hotels")
@Slf4j
@Tag(name = "Hotel (Public)", description = "Public hotel and hotel category browsing — no authentication required")
@SecurityRequirements
public class HotelController {
    private final HotelRepository hotelRepository;
    private final FloorRepository floorRepository;
    private final RoomRepository roomRepository;
    private final CategoryHotelRepository categoryHotelRepository;
    private MessageRes messageRes;

    public HotelController(HotelRepository hotelRepository, FloorRepository floorRepository,
                           RoomRepository roomRepository, CategoryHotelRepository categoryHotelRepository) {
        this.hotelRepository = hotelRepository;
        this.floorRepository = floorRepository;
        this.roomRepository = roomRepository;
        this.categoryHotelRepository = categoryHotelRepository;
    }

    @Operation(summary = "List hotels", description = "Pass type=ALL to list all hotels, or provide categoryHotelId to filter by category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/list")
    public ResponseEntity<Object> getAll(@RequestBody BasePostReq req) {
        messageRes = new MessageRes();
        List<Hotel> hotelList = new ArrayList<>();
        try {
            log.info("Intercept get all hotel req {}", req);
            if (req.getType().equals("ALL")) {
                hotelList = hotelRepository.findAllByStatusOrderByIdDesc(Constants.STATUS_ACTIVE);
            } else {
                hotelList = hotelRepository.findAllByCategoryHotelIdAndStatusOrderByIdDesc(
                        req.getCategoryHotelId(), Constants.STATUS_ACTIVE);
            }
            messageRes = new MessageRes();
            messageRes.setSuccess(hotelList);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get all hotel {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Get hotel by ID", description = "Returns hotel details including floors and rooms")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Hotel found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/getById/{id}")
    public ResponseEntity<Object> getHotelById(@RequestBody BasePostReq req, @PathVariable("id") Integer id) {
        messageRes = new MessageRes();
        try {
            log.info("Intercept get hotel by id {} req {}", id, req);
            Hotel hotel = hotelRepository.findByIdAndStatus(id, Constants.STATUS_ACTIVE);
            List<Floor> floorList = floorRepository.findAllByHotelIdAndStatus(hotel.getId(), Constants.STATUS_ACTIVE);
            if (!floorList.isEmpty()) {
                List<Floor> floors = new ArrayList<>();
                for (Floor floor : floorList) {
                    List<Room> rooms = roomRepository.findAllByFloorIdAndStatus(floor.getId(), Constants.STATUS_ACTIVE);
                    if (!rooms.isEmpty()) {
                        floor.setRooms(rooms);
                    }
                    floors.add(floor);
                }
                hotel.setFloors(floors);
            }
            messageRes = new MessageRes();
            messageRes.setSuccess(hotel);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get hotel by id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "List hotel categories")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/list")
    public ResponseEntity<Object> getAllCategoryHotels(@RequestBody BasePostReq req) {
        messageRes = new MessageRes();
        try {
            log.info("Intercept get all category hotel req {}", req);
            List<CategoryHotel> hotelList = categoryHotelRepository.findAllByStatus(Constants.STATUS_ACTIVE);
            messageRes = new MessageRes();
            messageRes.setSuccess(hotelList);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get all category hotel {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}