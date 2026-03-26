import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MissionDashboard } from './mission-dashboard.component';

describe('MissionDashboard', () => {
  let component: MissionDashboard;
  let fixture: ComponentFixture<MissionDashboard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MissionDashboard],
    }).compileComponents();

    fixture = TestBed.createComponent(MissionDashboard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
