package com.dinsaren.springbootjwtapi.controllers.rest.admin;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.CategoryHotel;
import com.dinsaren.springbootjwtapi.models.Hotel;
import com.dinsaren.springbootjwtapi.models.req.BasePostReq;
import com.dinsaren.springbootjwtapi.models.req.CreateHotelRequest;
import com.dinsaren.springbootjwtapi.models.res.MessageRes;
import com.dinsaren.springbootjwtapi.repository.CategoryHotelRepository;
import com.dinsaren.springbootjwtapi.repository.FloorRepository;
import com.dinsaren.springbootjwtapi.repository.HotelRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/app/admin/hotel")
@Slf4j
@Tag(name = "Admin - Hotel", description = "Admin hotel and hotel category management (ADMIN role required)")
@RequiredArgsConstructor
public class AdminHotelController {

    private final HotelRepository hotelRepository;
    private final CategoryHotelRepository categoryHotelRepository;
    private final FloorRepository floorRepository;
    private MessageRes messageRes;

    @Operation(summary = "List all hotels")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/list")
    public ResponseEntity<Object> getAll(@RequestBody BasePostReq req) {
        try {
            log.info("Intercept get all hotel by user id req {}", req);
            List<Hotel> hotelList = hotelRepository.findAllByStatusOrderByIdDesc(Constants.STATUS_ACTIVE);
            messageRes = new MessageRes();
            messageRes.setSuccess(hotelList);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get all hotel by user id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Get hotel by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Hotel found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/{id}")
    public ResponseEntity<Object> getById(@RequestBody BasePostReq req, @PathVariable("id") Integer id) {
        try {
            log.info("Intercept get hotel by req {}", req);
            Hotel object = hotelRepository.findById(id).orElse(null);
            messageRes = new MessageRes();
            messageRes.setSuccess(object);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get hotel by id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Create hotel")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Created successfully"),
            @ApiResponse(responseCode = "400", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/create")
    public ResponseEntity<Object> create(@RequestBody CreateHotelRequest req) {
        try {
            log.info("Intercept create hotel req {}", req);
            var category = categoryHotelRepository.findById(req.getCategoryHotelId());
            if (category.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Category not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            Hotel hotel = new Hotel();
            hotel.setDataCreate(req, category.get());
            hotelRepository.save(hotel);
            messageRes = new MessageRes();
            messageRes.setCreateSuccess("Create success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error create post : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Update hotel")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "400", description = "Hotel or category not found, or hotel is in use"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/update")
    public ResponseEntity<Object> update(@RequestBody CreateHotelRequest req) {
        try {
            log.info("Intercept update hotel req {}", req);
            var hotel = hotelRepository.findById(req.getId()).orElse(null);
            if (Objects.isNull(hotel)) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Hotel not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            var category = categoryHotelRepository.findById(req.getCategoryHotelId());
            if (category.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Category not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            var floors = floorRepository.findAllByHotelIdAndStatus(hotel.getId(), Constants.STATUS_ACTIVE);
            if (!floors.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Hotel has been used");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            req.setId(hotel.getId());
            hotel.setDataCreate(req, category.get());
            hotelRepository.save(hotel);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Update success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error hotel : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Delete hotel")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "400", description = "Hotel not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/delete")
    public ResponseEntity<Object> delete(@RequestBody CreateHotelRequest req) {
        try {
            log.info("Intercept update hotel req {}", req);
            var hotel = hotelRepository.findById(req.getId());
            if (hotel.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Hotel not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            hotel.get().setStatus(Constants.STATUS_ACTIVE);
            hotelRepository.save(hotel.get());
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Delete success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error delete hotel : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "List hotel categories")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/list")
    public ResponseEntity<Object> getAllCategory(@RequestBody BasePostReq req) {
        try {
            log.info("Intercept get all hotel category by user id req {}", req);
            List<CategoryHotel> categoryHotelList = categoryHotelRepository.findAllByStatus(Constants.STATUS_ACTIVE);
            messageRes = new MessageRes();
            messageRes.setSuccess(categoryHotelList);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get all hotel category by user id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Get hotel category by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Category found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/{id}")
    public ResponseEntity<Object> getCategortById(@RequestBody BasePostReq req, @PathVariable("id") Integer id) {
        try {
            log.info("Intercept get hotel category by req {}", req);
            CategoryHotel object = categoryHotelRepository.findById(id).orElse(null);
            messageRes = new MessageRes();
            messageRes.setSuccess(object);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get hotel category by id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Create hotel category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Created successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/create")
    public ResponseEntity<Object> createCategory(@RequestBody CategoryHotel req) {
        try {
            log.info("Intercept create category req {}", req);
            req.setStatus(Constants.STATUS_ACTIVE);
            categoryHotelRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setCreateSuccess("Create success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error create category : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Update hotel category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "400", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/update")
    public ResponseEntity<Object> updateCategory(@RequestBody CategoryHotel req) {
        try {
            log.info("Intercept update category req {}", req);
            var hotel = categoryHotelRepository.findById(req.getId());
            if (hotel.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Hotel not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            req.setStatus(Constants.STATUS_ACTIVE);
            categoryHotelRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Update success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error category : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Delete hotel category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "400", description = "Category not found or still in use by hotels"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/delete")
    public ResponseEntity<Object> deleteCategory(@RequestBody CategoryHotel req) {
        try {
            log.info("Intercept update post req {}", req);
            var categoryHotel = categoryHotelRepository.findById(req.getId());
            if (categoryHotel.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Category Hotel not found");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            var hotels = hotelRepository.findAllByCategoryHotelIdAndStatusOrderByIdDesc(categoryHotel.get().getId(), Constants.STATUS_ACTIVE);
            if (!hotels.isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setDataNotfound("Category Hotel has been used");
                return new ResponseEntity<>(messageRes, HttpStatus.BAD_REQUEST);
            }
            categoryHotel.get().setStatus(Constants.STATUS_ACTIVE);
            categoryHotelRepository.save(categoryHotel.get());
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Delete success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error delete post : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}