import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ObjectList } from './object-list.component';

describe('ObjectList', () => {
  let component: ObjectList;
  let fixture: ComponentFixture<ObjectList>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ObjectList],
    }).compileComponents();

    fixture = TestBed.createComponent(ObjectList);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
