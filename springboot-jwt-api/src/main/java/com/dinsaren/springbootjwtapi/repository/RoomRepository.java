package com.dinsaren.springbootjwtapi.repository;
import com.dinsaren.springbootjwtapi.models.Room;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomRepository extends JpaRepository<Room, Integer> {
  List<Room> findAllByFloorIdAndStatus(Integer floorId, String status);
}
