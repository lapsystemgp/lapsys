import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { BookingStatus, Role } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LabActiveGuard } from '../auth/guards/lab-active.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AvailabilityQueryDto } from './dto/availability-query.dto';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { LabBookingStatusDto } from './dto/lab-booking-status.dto';

type RequestWithUser = {
  user?: { id?: string };
};

@Controller('bookings')
@UseGuards(JwtAuthGuard, RolesGuard)
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Get('availability')
  @Roles(Role.Patient)
  getAvailability(@Query() query: AvailabilityQueryDto) {
    return this.bookingsService.getAvailability(query);
  }

  @Post()
  @Roles(Role.Patient)
  createBooking(@Req() req: RequestWithUser, @Body() dto: CreateBookingDto) {
    return this.bookingsService.createBooking(req.user?.id ?? '', dto);
  }

  @Get('patient')
  @Roles(Role.Patient)
  listPatientBookings(@Req() req: RequestWithUser) {
    return this.bookingsService.listPatientBookings(req.user?.id ?? '');
  }

  @Patch(':bookingId/patient-cancel')
  @Roles(Role.Patient)
  cancelByPatient(@Req() req: RequestWithUser, @Param('bookingId') bookingId: string) {
    return this.bookingsService.cancelByPatient(req.user?.id ?? '', bookingId);
  }

  @Get('lab')
  @Roles(Role.LabStaff)
  @UseGuards(LabActiveGuard)
  listLabBookings(@Req() req: RequestWithUser) {
    return this.bookingsService.listLabBookings(req.user?.id ?? '');
  }

  @Patch(':bookingId/lab-status')
  @Roles(Role.LabStaff)
  @UseGuards(LabActiveGuard)
  setLabBookingStatus(
    @Req() req: RequestWithUser,
    @Param('bookingId') bookingId: string,
    @Body() dto: LabBookingStatusDto,
  ) {
    return this.bookingsService.setLabBookingStatus(
      req.user?.id ?? '',
      bookingId,
      dto.status as BookingStatus,
    );
  }
}
