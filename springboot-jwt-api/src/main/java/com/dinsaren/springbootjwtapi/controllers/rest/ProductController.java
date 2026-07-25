package com.dinsaren.springbootjwtapi.controllers.rest;

import com.dinsaren.springbootjwtapi.constants.Constants;
import com.dinsaren.springbootjwtapi.models.product.Product;
import com.dinsaren.springbootjwtapi.models.product.ProductCategory;
import com.dinsaren.springbootjwtapi.models.req.BasePostReq;
import com.dinsaren.springbootjwtapi.models.res.MessageRes;
import com.dinsaren.springbootjwtapi.repository.ProductCategoryRepository;
import com.dinsaren.springbootjwtapi.repository.ProductRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/app/product")
@Slf4j
@Tag(name = "Product", description = "Product and product category management")
//@PreAuthorize("hasRole('USER') or hasRole('CUSTOMER') or hasRole('ADMIN') or hasRole('MERCHANT')")
@RequiredArgsConstructor
public class ProductController {

    private final ProductCategoryRepository productCategoryRepository;
    private final ProductRepository productRepository;
    private MessageRes messageRes;

    @Operation(summary = "List product categories")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/list")
    public ResponseEntity<Object> getAll(@RequestBody BasePostReq req) {
        try {
            List<ProductCategory> brands = productCategoryRepository.findAll();
            messageRes = new MessageRes();
            messageRes.setSuccess(brands);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.error("Error internal error get all category by user id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Get product category by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Category found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/{id}")
    public ResponseEntity<Object> getById(@RequestBody BasePostReq req, @PathVariable("id") int id) {
        try {
            ProductCategory object = productCategoryRepository.findById(id).orElse(null);
            messageRes = new MessageRes();
            messageRes.setSuccess(object);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.error("Error internal error get category by id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Create product category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Created successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/create")
    public ResponseEntity<Object> create(@RequestBody ProductCategory req) {
        try {
            productCategoryRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setCreateSuccess("Create category success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error create category : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Update product category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "404", description = "Category not found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/update")
    public ResponseEntity<Object> update(@RequestBody ProductCategory req) {
        try {
            if (productCategoryRepository.findById(req.getId()).orElse(null) == null) {
                messageRes = new MessageRes();
                messageRes.dataNotFound("Category not found");
                return new ResponseEntity<>(messageRes, HttpStatus.OK);
            }
            productCategoryRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Update category success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error update category : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Delete product category")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "400", description = "Category in use by a product"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/category/delete")
    public ResponseEntity<Object> delete(@RequestBody ProductCategory req) {
        try {
            if (productCategoryRepository.findById(req.getId()).orElse(null) == null) {
                messageRes = new MessageRes();
                messageRes.dataNotFound("Category not found");
                return new ResponseEntity<>(messageRes, HttpStatus.OK);
            }
            if (!productRepository.findAllByCategory_Id(req.getId()).isEmpty()) {
                messageRes = new MessageRes();
                messageRes.setMessageDeleteCategory("Category already used by product");
                return new ResponseEntity<>(messageRes, HttpStatus.OK);
            }
            productCategoryRepository.delete(req);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Delete category success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error delete category : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "List products", description = "Pass status=ALL to include deleted products")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "List returned successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/list")
    public ResponseEntity<Object> getAllProducts(@RequestBody BasePostReq req) {
        try {
            List<String> stringList = new ArrayList<>();
            if (req.getStatus().equals("ALL")) {
                stringList.add(Constants.STATUS_ACTIVE);
                stringList.add(Constants.STATUS_DELETE);
                List<Product> list = productRepository.findAllByStatusInOrderByIdDesc(stringList);
                messageRes = new MessageRes();
                messageRes.setSuccess(list);
            }
            if (req.getStatus() == null) {
                stringList.add(Constants.STATUS_ACTIVE);
                List<Product> list = productRepository.findAllByStatusInOrderByIdDesc(stringList);
                messageRes = new MessageRes();
                messageRes.setSuccess(list);
            }
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Throwable e) {
            log.error("Error internal error get all product by user id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Get product by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Product found"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/{id}")
    public ResponseEntity<Object> getProductById(@RequestBody BasePostReq req, @PathVariable("id") int id) {
        try {
            Product object = productRepository.findById(id).orElse(null);
            messageRes = new MessageRes();
            messageRes.setSuccess(object);
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error get product by id {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Create product")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Created successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/create")
    public ResponseEntity<Object> createProduct(@RequestBody Product req) {
        try {
            productRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setCreateSuccess("Create product success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error create product : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Update product")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Updated successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/update")
    public ResponseEntity<Object> updateProduct(@RequestBody Product req) {
        try {
            productRepository.save(req);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Update product success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error update product : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Operation(summary = "Delete product")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Deleted successfully"),
            @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PostMapping("/delete")
    public ResponseEntity<Object> delete(@RequestBody Product req) {
        try {
            productRepository.delete(req);
            messageRes = new MessageRes();
            messageRes.setUpdateSuccess("Delete product success");
            return new ResponseEntity<>(messageRes, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error internal error delete product : {}", e.toString());
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}