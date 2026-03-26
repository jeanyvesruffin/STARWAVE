import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ExplorerHome } from './explorer-home.component';

describe('ExplorerHome', () => {
  let component: ExplorerHome;
  let fixture: ComponentFixture<ExplorerHome>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExplorerHome],
    }).compileComponents();

    fixture = TestBed.createComponent(ExplorerHome);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
