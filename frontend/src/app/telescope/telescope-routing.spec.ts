import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TelescopeRouting } from './telescope-routing';

describe('TelescopeRouting', () => {
  let component: TelescopeRouting;
  let fixture: ComponentFixture<TelescopeRouting>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TelescopeRouting],
    }).compileComponents();

    fixture = TestBed.createComponent(TelescopeRouting);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
