import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ControlPanel } from '../../app/telescope/pages/control-panel.component';

describe('ControlPanel', () => {
  let component: ControlPanel;
  let fixture: ComponentFixture<ControlPanel>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ControlPanel],
    }).compileComponents();

    fixture = TestBed.createComponent(ControlPanel);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
